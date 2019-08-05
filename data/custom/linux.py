import xml.etree.ElementTree as ET
import sys

root = ET.parse('/home/urosjarc/vcs/mylinux/data/custom/matlab_shortcuts.xml').getroot()
for context in root.findall('Context'):
    print(f"\n{context.get('id')}\n")
    for action in context.findall('Action'):
        strokes = []
        for stroke in action.findall('Stroke'):
            if 'meta' not in stroke.attrib:
                meta = ''
                code = None
                for key, val in stroke.attrib.items():
                    if key == 'code':
                        code = val.replace('VK_', '').lower()
                    elif val == 'on':
                        meta += f'{key}+'
                    else:
                        raise Exception(stroke.attrib)
                strokes.append(f'{meta}{code}')
        print('\t{:.<30} {}'.format(action.get('id')+' ', ', '.join(strokes)))

sys.exit(0)
