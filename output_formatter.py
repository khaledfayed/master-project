import json
f = open('output.json')
output = json.load(f)
if 'errors' in output:
    for i in output['errors']:
        print(i['formattedMessage'])
else:
    print('No errors')    