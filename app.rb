$: << './lib'

Dir['lib/*'].each {|x| require x.match(/lib\/([^.]+)\.rb/)[1] }
