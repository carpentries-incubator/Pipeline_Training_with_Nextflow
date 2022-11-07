process make_files_one {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}_s_one.txt; done"""
}

process make_files_two {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}_s_two.txt; done"""
}


process grouped_files {
   echo true

   input:
   tuple file(first_file), file(second_file)
   """echo 'I have ${first_file} and ${second_file}'"""
}

workflow {
   make_files_one()
   make_files_two()
   // Label the files with their prefix
   files_one = make_files_one.out.flatten().map{ it -> [it.baseName.split("_s_")[0], it ] }
   files_two = make_files_two.out.flatten().map{ it -> [it.baseName.split("_s_")[0], it ] }
   grouped_files(
       // Concat them with the other process
       files_one.concat(files_two).
       // Group the files by this prefix then remove the prefix
       groupTuple().map { it -> [ it[1][0], it[1][1] ] }
    )
}