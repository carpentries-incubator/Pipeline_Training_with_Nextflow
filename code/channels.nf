process make_files {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}.txt; done"""
}

process each_file {
   echo true

   input:
   file each_file

   """echo 'I have each file: ${each_file}'"""
}

process all_files {
   echo true

   input:
   file all_files

   """echo 'I have all files: ${all_files}'"""
}

workflow {
   make_files()
   each_file(make_files.out.flatten().view{"flatten: $it.baseName"})
   all_files(make_files.out.collect().view{"collect: $it.baseName"})
}