include ChefUtils::MySQL
include ChefUtils::Password

action :create do
  password = new_resource.password
  if password.to_s == ""
    if new_resource.host == "localhost"
      password = get_password("mysql/#{new_resource.name}", 16)
    else
      password = get_password("mysql/#{new_resource.name}_#{new_resource.host}", 16)
    end
  end
  if new_resource.force_password
    if mysql_user_exists?(new_resource)
      mysql_force_password(new_resource, password)
    else
      mysql_create_user(new_resource, password)
    end
  elsif !mysql_user_exists?(new_resource)
    mysql_create_user(new_resource, password)
  end
end

action :delete do
  drop_mysql_user(new_resource) if mysql_user_exists?(new_resource)
end
