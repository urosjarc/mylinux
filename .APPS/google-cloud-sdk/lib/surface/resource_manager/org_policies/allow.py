# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Command to add values to an Organization Policy whitelist."""

from googlecloudsdk.api_lib.resource_manager import exceptions
from googlecloudsdk.api_lib.resource_manager import org_policies
from googlecloudsdk.calliope import base
from googlecloudsdk.command_lib.resource_manager import org_policies_base
from googlecloudsdk.command_lib.resource_manager import org_policies_flags as flags


@base.ReleaseTracks(base.ReleaseTrack.ALPHA, base.ReleaseTrack.BETA)
class Allow(base.Command):
  """Add values to an Organization Policy allowed_values list policy.

  Adds one or more values to the specified Organization Policy allowed_values
  list policy associated with the specified resource.

  ## EXAMPLES

  The following command adds `devEnv` and `prodEnv` to an Organization Policy
  allowed_values list policy for constraint `serviceuser.services`
  on project `foo-project`:

    $ {command} serviceuser.services --project=foo-project devEnv prodEnv
  """

  @staticmethod
  def Args(parser):
    flags.AddIdArgToParser(parser)
    flags.AddResourceFlagsToParser(parser)
    base.Argument(
        'allowed_value',
        metavar='ALLOWED_VALUE',
        nargs='+',
        help='The values to add to the allowed_values list policy.',
    ).AddToParser(parser)

  def Run(self, args):
    flags.CheckResourceFlags(args)
    messages = org_policies.OrgPoliciesMessages()
    service = org_policies_base.OrgPoliciesService(args)

    policy = service.GetOrgPolicy(org_policies_base.GetOrgPolicyRequest(args))

    if policy.booleanPolicy or (
        policy.listPolicy and
        (policy.listPolicy.deniedValues or policy.listPolicy.allValues)):
      raise exceptions.ResourceManagerError(
          'Cannot add values to a non-allowed_values list policy.')

    if policy.listPolicy and policy.listPolicy.allowedValues:
      for value in args.allowed_value:
        policy.listPolicy.allowedValues.append(unicode(value))
    else:
      policy.listPolicy = messages.ListPolicy(allowedValues=args.allowed_value)

    return service.SetOrgPolicy(
        org_policies_base.SetOrgPolicyRequest(args, policy))
