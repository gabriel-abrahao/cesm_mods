#!/bin/bash
./*.sdumont.submit | tee /dev/tty | grep 'Submitted batch job' | sed 's/Submitted batch job \([0-9][0-9]*\)/\1/' >lastsubmit
