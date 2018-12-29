# mhs52xxA
MacOS/OSX program to control MHS-5200 series signal generators

This signal generator / frequency counter comes under a number of different brand names.  It is often numbered MHS-5200.  Mine is specifically MHS-5225A wih firmware 5.04, so that is what it has been tested with initially.  Branding is 'KMOON'.

This unit is a 12-bit version with 2048 sample points for the arbitrary waveforms.  It also has the TTLS plug in the back.

So, for those not interested/willing to use windows .. here is a 100% OSX/MacOS command line program written in Swift 4.2.  It has been written in the most generic way possible so I'd expect it will work with a number of other like units out there.  Also, it is written in a way that puts the onus on you to provide good data.  The data point file, for instance, isn't checked for the correct length -- so those with only 1024 point versions can use it too.  Commands sent to unit arn't checked at all.  So, I've included a sheet of commands that others have written and also one that I've vetted on this unit.

The gist of how the program works is you simply provide the serial device path, then you chain each command you want sent to the unit in the order you wish them sent.  There are three types of commands to send, one that expects just 'ok', another that expects a result, and a third that allows you to reference a file with data points to upload for the arbitrary waveform generator.

This repository has a pre-built version of the program in it in a *.tgz file if you don't want to fire up XCode compiler.

There is a YouTube video demonstrating usage of this tool at https://youtu.be/43wMURP_9eg 
