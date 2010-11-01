define :rvm_wrapper, :code => "", :owner => "root", :group => "root", :mode => "0755" do
  file params[:name] do
    content <<-EOS
#!/bin/bash
source /usr/local/rvm/scripts/rvm
#{params[:code]}
EOS
    owner params[:owner]
    group params[:group]
    mode params[:mode]
  end
end
