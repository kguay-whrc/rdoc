# TODO: deal with split lines
#        starting with "#   "

import sys, os

file = open('test.R', 'rb')
lines = file.readlines()

markdown = open('test.md', 'w')
first_param = True
param = False

# FLAGS
start_bold = False
start_toc = True

# Preview and pull out header and function names for table of context
for l in range(1,len(lines)):
   line = lines[l]
   line = line.lstrip()
   if(line.startswith('##')):
      line = line.replace('##','')
      line = line.lstrip()
      
      if(line.startswith('@author')):
         markdown.write('\n' + line.replace('@author', '**Author**: '))
         lines[l] = ''
      if(line.startswith('@contributer')):
         markdown.write('\n' + line.replace('@contributer', '**Contributer**: '))
         lines[l] = ''
      if(line.startswith('@version')):
         markdown.write('\n' + line.replace('@version', '**Version**: '))
         lines[l] = ''
      if(line.startswith('@since')):
         markdown.write('\n' + line.replace('@since', '**Created**: '))
         lines[l] = ''
   else:
      if('function' in line):
         if(lines[l+1].lstrip().startswith('##')):
            if(start_toc == True):
               markdown.write('\n#### Functions'); start_toc=False
            markdown.write('\n- **' + line.split(' ')[0] + '**')

markdown.write('\n\n')
      

for l in range(1,len(lines)):
   line = lines[l]
   line = line.lstrip()
   if(line.startswith('##')):
      # remove any leading spaces
      line.lstrip()
   
      line = line.replace('##','')
      line = line.lstrip()
      line = line.replace('@synt', '\n##### Syntax\n')
      line = line.replace('@desc', '\n##### Description\n')
      line = line.replace('@return', '\n##### Return\n').lstrip()
      line = line.replace('@examp', '\n##### Example\n')
      if(line.startswith('@param')):
         param = True
         if(first_param == True):
            first_param = False
            line = line.replace('@param', '\n##### Parameters\nname|desc\n---|---\n')
            line = line.replace(':', '|')
         else:
            line = line.replace('@param', '').lstrip().replace(':', '|')
      else:
         if(param == True):
            markdown.write('\n')
            first_param = True
            
      markdown.write(line)
      
   else:
      if('function' in line):
         if(lines[l+1].lstrip().startswith('##')):
            markdown.write('\n---\n###' + line.split(' ')[0] + '\n')
      
            

markdown.close()






