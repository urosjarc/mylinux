import datetime
from typing import List, Tuple

import requests


class Client:
    def __init__(self, name, email):
        self.name = name
        self.email = email

    def __str__(self):
        return f'Client(name={self.name}, email={self.email})'


class InvoiceItem:
    def __init__(self, client, json):
        self.client = client
        self.name = json['name']
        self.quantity = json['quantity']
        self.unit = json['unit_amount']['value']
        self.currency = json['unit_amount']['currency_code']
        ymd = (int(ele) for ele in json['item_date'].split('-'))
        self.date = datetime.date(*ymd)

    def __str__(self):
        return f'InvoiceItem(name={self.name}, quantity={self.quantity}, date={self.date})'


class Invoice:
    def __init__(self, json):
        billing_info = json['primary_recipients'][0]['billing_info']

        self.id = json['id']
        self.status = json['status']
        self.createdAt = json['detail']['metadata']['create_time']
        self.view_url = json['detail']['metadata']['invoicer_view_url']
        self.client = Client(
            name=billing_info['name']['full_name'],
            email=billing_info['email_address'])

        self.items: List[InvoiceItem] = [InvoiceItem(self.client, item) for item in json['items']]

    def __str__(self):
        return f'Invoice(id={self.id},client={self.client}, items={len(self.items)})'


class PayPal:
    api_url = "https://api-m.paypal.com"
    client_id = "AdQ4ChZysQOEpMDJVVCE1okg0-4_2b6WTgFtyniEbIWgvrS78FnSuDreSPTp9pQXhrfX2egOAQ13ZROC"
    secret = "ECOl0v8Ji2IpGStHeX_ZBZ9ar-bCgWu4rSNGch-Rsae9GfChb7GzwnsimFMsOAOkTKnz4zY_3xd2wkqM"

    def __init__(self):
        self.session = requests.Session()
        self.session.auth = (self.client_id, self.secret)
        self.session.post(
            self.v1_url('oauth2/token'),
            data={"grant_type": "client_credentials"},
            headers={'Content-Type': 'application/x-www-form-urlencoded'})

    def v1_url(self, path: str):
        url = f'{self.api_url}/v1/{path}'
        return url

    def v2_url(self, path: str):
        url = f'{self.api_url}/v2/{path}'
        return url

    def invoices(self):
        body = self.session.get(self.v2_url('invoicing/invoices'), params={
            'page': 1,
            'page_size': 100,
            'total_required': True
        }).json()

        invoices = []
        for invoice_info in body['items']:
            invoice_details = self.invoice(invoice_info['id'])
            invoice = Invoice(invoice_details)
            invoices.append(invoice)
        return invoices

    def invoice(self, id):
        return self.session.get(self.v2_url(f'invoicing/invoices/{id}')).json()


paypal = PayPal()

# FILL CALENDAR
now = datetime.date.today()
calendar = {now - datetime.timedelta(days=i): [] for i in range(14)}
for invoice in paypal.invoices():
    for item in invoice.items:
        if item.date not in calendar:
            continue
        else:
            calendar[item.date].append(item)

calendar: List[Tuple[datetime.datetime, List[InvoiceItem]]] = sorted(list(calendar.items()), key=lambda ele: ele[0],
                                                                     reverse=False)
for date, items in calendar:
    if len(items) == 0:
        print(f'{date} /////////////////')
    else:
        print(f'{date}')

    for item in items:
        print(f'    * {item.quantity:<4}min => {item.client.name}')
    print()
