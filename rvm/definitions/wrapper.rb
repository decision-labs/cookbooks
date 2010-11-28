define :rvm_wrapper, :code => "", :user => "root", :mode => "0755" do
  rvm = node[:rvm][:instance][params[:user]]

  file params[:name] do
    content <<-EOS
#!/bin/bash
export HOME=~#{rvm[:user]}
source /usr/local/rvm/scripts/rvm
#{params[:code]}
EOS
    owner rvm[:user]
    group rvm[:group]
    mode params[:mode]
  end
end
