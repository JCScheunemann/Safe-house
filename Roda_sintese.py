import fileinput
import os
import shutil
import string
import sys

Tamanhos=[8,16]
print "Iniciando..."
print "sinteze para os seguintes tamanhos"
print Tamanhos
for i in Tamanhos:
	print "Iniciando a sinteze para "+str(i)+" bits"
	os.system("echo '`define TAM "+str(i)+" '>const.v")
	os.system("irun -64 *.v *.vhd -linedebug -access rwc -top tb_multipliers -q")
	os.system("rc -64 -bg -f  setupe_marlon.tcl -post exit")
	print "finalizado a sinteze para "+str(i)+" bits, Iniciando a coleta de dados"
	os.system("mkdir -p resultados/"+str(i)+"_bits")
	os.system("rm -rf resultados/"+str(i)+"_bits/*")
	os.system("mv -f reports_DUT/* resultados/"+str(i)+"_bits/")
	os.system("rm -rf rc.cmd*")
	os.system("rm -rf rc.log*")
	os.system("rm -rf INCA_libs/")
	os.system("rm -rf logs/")
	os.system("rm -rf outputs/")
	os.system("rm -rf results/")
	os.system("rm -rf reports_DUT/")
	os.system("rm -rf waves.shm/")
	os.system("rm -rf irun.log")
	os.system("rm -rf irun.key")
	os.system("rm -rf multiplication.vcd")
for i in Tamanhos:
	print "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
	print "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
	print "************************** report "+str(i)+" bits*******************<<<<<<<<<<<<"+str(i)+" bits"
	print "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
	os.system("cat resultados/"+str(i)+"_bits/RC_power_short.txt")
	print "____________________________________________________________________"
