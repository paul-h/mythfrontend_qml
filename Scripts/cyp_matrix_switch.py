#!/usr/bin/env python

# This file is part of MythTV.
# Copyright 2017, Paul Harrison.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

"""Various utilities for controlling a CYP HDMI Matrix Switch"""

from __future__ import print_function

from optparse import OptionParser
import sys
import pprint

import telnetlib

__author__      = "Paul Harrison'"
__title__       = "CYP Matrix Switch utilities"
__description__ = "Various utilities for controlling a CYP HDMI Matrix Switch"
__version__     = "0.1"


HOST = "192.168.1.140"

debug = False

telnet = None

def log(debug, txt):
    if debug:
        print(txt)

def openTelnet():
    global telnet

    if telnet == None:
        telnet = telnetlib.Telnet(HOST)
        telnet.read_until("Welcome to TELNET.")

def closeTelnet():
    global telnet

    if telnet != None:
        telnet.write('\x1d')
        telnet.write("exit\n")

def getStatus():
    openTelnet()

    telnet.write("INFO\n")

    result = telnet.read_until(">")

    power = ''
    outputA = ''
    outputB = ''
    mode = ''

    lines = result.split('\r\n')
    for line in lines:
        if line.startswith("POWER STATUS: "):
            power = line.replace("POWER STATUS: ", "")
        if line.startswith("OUTPUT A: "):
            outputA = line.replace("OUTPUT A: ", "")
        if line.startswith("OUTPUT B: "):
            outputB = line.replace("OUTPUT B: ", "")
        if line.startswith("MATRIX MODE: "):
            mode = line.replace("MATRIX MODE: ", "")

    return (power, outputA, outputB, mode)

def getStatusXML():
    from lxml import etree

    power, outputA, outputB, mode = getStatus()

    status = etree.XML(u'<status></status>')
    etree.SubElement(status, "power").text = power
    etree.SubElement(status, "output_a").text = outputA
    etree.SubElement(status, "output_b").text = outputB
    etree.SubElement(status, "matrix_mode").text = mode

    log(True, etree.tostring(status, encoding='UTF-8', pretty_print=True,
                             xml_declaration=True))

    closeTelnet()
    sys.exit(0)

def setPowerState(state):
    global telnet

    openTelnet()

    power, outputA, outputB, mode = getStatus()

    if power != state:
        if state == "ON":
            command = "P1\n"
        else:
            command = "P0\n"

        telnet.write(command)
        telnet.read_until(">")

    closeTelnet()
    sys.exit(0)

def setMatrixMode(newMode):
    global telnet

    openTelnet()

    power, outputA, outputB, mode = getStatus()

    if newMode != mode:
        if newMode == "MATRIX":
            command = "MATRIXMODE 0\n"
        else:
            command = "MATRIXMODE 1\n"

        telnet.write(command)
        print(telnet.read_until(">"))

    closeTelnet()
    sys.exit(0)

def setInput(input, output):
    global telnet

    openTelnet()

    telnet.write(output + input + "\n")
    print(telnet.read_until(">"))

    closeTelnet()
    sys.exit(0)

def buildVersion():
    from lxml import etree
    version = etree.XML(u'<version></version>')
    etree.SubElement(version, "name").text = __title__
    etree.SubElement(version, "author").text = __author__
    etree.SubElement(version, "command").text = 'matrix_switch.py'
    etree.SubElement(version, "description").text = __description__
    etree.SubElement(version, "version").text = __version__

    log(True, etree.tostring(version, encoding='UTF-8', pretty_print=True,
                             xml_declaration=True))
    sys.exit(0)

def performSelfTest():
    err = 0
    try:
        import telnetlib
    except:
        err = 1
        print ("Failed to import python telnetlib library. Is telnetlib installed?")
    try:
        import lxml
    except:
        err = 1
        print("Failed to import python lxml library.")

    if not err:
        print("Everything appears in order.")
    sys.exit(err)

def main():
    global debug
    global telnet

    parser = OptionParser()

    parser.add_option('-v', "--version", action="store_true", default=False,
                      dest="version", help="Display version and author")

    parser.add_option('-t', "--test", action="store_true", default=False,
                      dest="test", help="Perform self-test for dependencies.")

    parser.add_option('-g', "--getstatus", action="store_true", default=False,
                      dest="getstatus", help="Get the matrix switches status")

    parser.add_option('-r', "--power", metavar="STATE", default=False,
                      dest="power", help="Turns the matrix switch ON/OFF.")

    parser.add_option('-m', "--mode", metavar="MODE", default=False,
                      dest="mode", help="Switches the mode of the matrix switch MATRIX/PREVIEW.")

    parser.add_option('-d', '--debug', action="store_true", default=False,
                      dest="debug", help=("Show debug messages"))

    parser.add_option('-s', "--setinput", action="store_true", default=False,
                      dest="setinput", help="Change an output to a given input. Requires --input/--output.")

    parser.add_option('-o', '--output', metavar="OUTPUT", default=None,
                      dest="output", help=("Output to use A/B"))

    parser.add_option('-i', '--input', metavar="INPUT", default=None,
                      dest="input", help=("Input to use 1/2/3/4/5/6"))

    opts, args = parser.parse_args()

    if opts.debug:
        debug = True

    if opts.version:
        buildVersion()

    if opts.test:
        performSelfTest()

    if opts.getstatus:
        getStatusXML()

    if opts.power:
        state = opts.power

        if state != "ON" and state != "OFF":
            print("Invalid parameter '" + state + "' for --power argument")
            sys.exit(1)

        setPowerState(state)

    if opts.mode:
        mode = opts.mode

        if mode != "MATRIX" and mode != "PREVIEW":
            print("Invalid parameter '" + mode + "' for --mode argument")
            sys.exit(1)

        setMatrixMode(mode)

    if opts.setinput:
        if opts.input == None:
            print("Missing --input argument")
            sys.exit(1)

        if opts.output == None:
            print("Missing --output argument")
            sys.exit(1)

        if opts.output != "A" and opts.output != "B":
            print("Invalid parameter '" + opts.output + "' for --output argument")
            sys.exit(1)

        input = int(opts.input)
        if input < 1 or input > 6:
            print("Invalid parameter '" + opts.input + "' for --input argument")
            sys.exit(1)

        setInput(opts.input, opts.output)

    sys.exit(0)

if __name__ == '__main__':
    main()
