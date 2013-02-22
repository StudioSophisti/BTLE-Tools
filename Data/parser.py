#!/usr/bin/env python
# encoding: utf-8
"""
untitled.py

Created by Tijn Kooijmans on 2012-03-23.
Copyright (c) 2012 __MyCompanyName__. All rights reserved.
"""

import sys
import os
import xlrd
import codecs
import time

def parseSheet(sheet, file, name):
	if sheet.nrows == 0:
		 return

	for r in range(sheet.nrows)[1:]:
		row = sheet.row(r)
		key = row[0].value
		value = row[1].value
		if (key):
			if (value):
				value = value.replace("\"","\\\"")
				
				#translators sometimes screw up my placeholders, so fix it:
				value = value.replace('d%','%d')
				value = value.replace('@%','%@')
				
				file.write("\"%s\" = \"%s\";\r\n" % (key, value))
			
			else:
				file.write("//%s\r\n" % key)
		else:
			file.write("\r\n")	
			
	file.write("\r\n")
	file.write("\r\n")
	file.flush()
	
def languageParse(excelBestand):
	
	print "Parsing %s" % excelBestand
	fileout = codecs.open("output.strings", "a", "utf-16")
	fileout.write("\n")
	fileout.write("// Parsed from: %s, on %s\r\n\r\n" 
		% (excelBestand, time.strftime("%a %d %b %Y %H:%M:%S")))
	book = xlrd.open_workbook(excelBestand)
	parseSheet(book.sheet_by_index(0), fileout, "SERVICES")
		
	fileout.close()

def usage():
    print "usage: <excelfile>"

def main(argv=None):
    if argv is None:
        argv = sys.argv
        			
	languageParse(argv[1])

if __name__ == "__main__":
    sys.exit(main())