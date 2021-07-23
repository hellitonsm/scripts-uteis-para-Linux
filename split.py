import PyPDF2
from PyPDF2 import PdfFileWriter

import sys

file = str(sys.argv[1])

def bookmark_dict(bookmark_list):
    result = {}
    for item in bookmark_list:
        if isinstance(item, list):
            # recursive call
            result.update(bookmark_dict(item))
        else:
            result[reader.getDestinationPageNumber(item)] = item.title
    return result


reader = PyPDF2.PdfFileReader(file)

get = bookmark_dict(reader.getOutlines())

print("list:")

ajuste = {}
for key in get:
    ajuste[key+1] = get[key].replace('\r', ' ')

for a in ajuste:
    output = PdfFileWriter()
    output.addPage(reader.getPage(a-1))
    with open("%s.pdf" % ajuste[a], "wb") as outputStream:
        output.write(outputStream)
    
