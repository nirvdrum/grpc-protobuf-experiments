# frozen_string_literal: true

require "rake/testtask"
require "tempfile"

ENV["PATH"] = "exe:#{ENV["PATH"]}"

PROTO_PATH = "#{__dir__}/proto/"

desc "Clobber generated source files"
task :clobber do
  rm_rf "gen"
end

desc("Generate proto files with protoc")
task generate: Rake::FileList["gen/protobuf"]

desc("Generate proto files with protoboeuf")
task generate_protoboeuf: Rake::FileList["gen/protoboeuf"]

desc("Generate proto files")
rule "gen/protobuf" => ->(_) { FileList["#{PROTO_PATH}/*.proto"] } do
  mkdir_p "gen/protobuf"
  sh "protoc --version"

  proto_files = FileList["#{PROTO_PATH}/**/*.proto"].gsub(%r{^#{PROTO_PATH}/}, "")
  sh "protoc -I #{PROTO_PATH} -I . --ruby_out=gen/protobuf #{proto_files.join(" ")}"

  sh "touch gen" # HACK: force rake to treat gen as up to date
end

desc("Generate proto files")
rule "gen/protoboeuf" => ->(_) { FileList["#{PROTO_PATH}/*.proto"] } do
  mkdir_p "gen/protoboeuf"
  sh "protoc --version"

  proto_files = FileList["#{PROTO_PATH}/**/*.proto"].gsub(%r{^#{PROTO_PATH}/}, "")
  proto_files.each do |proto_file|
    binary_file = "gen/protoboeuf/#{proto_file.sub(".proto", ".bproto")}"
    sh "protoc -I #{PROTO_PATH} -I . #{proto_file} --descriptor_set_out #{binary_file}"
    sh "bundle exec protoboeuf --bin #{binary_file} > gen/protoboeuf/#{proto_file.sub(".proto", ".rb")}"
  end

  sh "touch gen" # HACK: force rake to treat gen as up to date
end

task default: [:generate, :generate_protoboeuf]
