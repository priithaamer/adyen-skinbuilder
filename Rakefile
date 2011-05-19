require 'bundler'
Bundler::GemHelper.install_tasks

desc 'Generate TODO.markdown using DNote'
task :todolist do
  `dnote --format md --output TODO.markdown --title "TODO list"`
end