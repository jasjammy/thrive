#!/usr/bin/ruby
require 'pathname'
require 'json'

class Company
  attr_reader :id, :top_up
  attr_accessor :users, :users_emailed, :users_not_emailed, :total_top_ups
  def initialize(id, name, top_up, email_status)
    @id = id
    @name = name
    @top_up = top_up
    @email_status = email_status
    @users_emailed = []
    @users_not_emailed = []
    @total_top_ups = 0
  end

  # def valid?
  #   presence = @id && @name && @email_status != nil && @top_up
  #   # valid_types = @id.is_a?(Integer) && @name.is_a?(String) && @email_status.is_a(Boolean) && @top_up.is_a?(Integer)
  #   puts "Company id #{@id} : Presence : #{presence}, Valid Types: #{valid_types}"
  #   presence && valid_types
  # end

  def user_email_list(user)
    if user.email_status && @email_status then
      @users_emailed << user
    else
      @users_not_emailed << user
    end
  end

  def print_company
    output_str = "\nCompany Id: " + @id.to_s + "\n" + "Company Name: " + @name + "\n"
    # Order users in list
    @users_emailed = @users_emailed.sort_by {|obj| obj.last_name}
    @users_not_emailed = @users_not_emailed.sort_by {|obj| obj.last_name}

    output_str = output_str + "Users Emailed:\n"

    @users_emailed.each do |user|
      @total_top_ups = @total_top_ups + user.update_tokens(@top_up)
      output_str = output_str + user.print_user + "\n"
    end

    output_str = output_str + "Users Not Emailed:\n"
    @users_not_emailed.each do |user|
      @total_top_ups = @total_top_ups + user.update_tokens(@top_up)
      output_str = output_str + user.print_user + "\n"
    end
    output_str = output_str + "  Total amount of top ups for #{@name}: #{@total_top_ups}\n"

    output_str
  end
end

class Users
  attr_reader :first_name, :last_name, :email_status, :prev_tokens, :new_tokens
  def initialize(id, first_name, last_name, email,
    company_id, email_status, active_status, tokens)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @email = email
    @company_id = company_id
    @email_status = email_status
    @active_status = active_status
    @prev_tokens = tokens
    @new_tokens = tokens
  end

  # def valid?
  #   email_regex = /^(.+)@(.+)$/
  #   presence = @id && @first_name && @last_name && @email_status != nil &&
  #   @active_status != nil && @tokens && @email
  #   # valid_types = @id.is_a?(Integer) && @company_id.is_a?(Integer) && @name.is_a?(String) &&
  #   #   @email_status.is_a(Boolean) && @active_status.is_a(Boolean) && @tokens.is_a?(Integer) &&
  #   #    @email.is_a(String) && @email =~ email_regex
  #   presence && valid_types
  # end

  def update_tokens(top_up)
    if @active_status then
      @new_tokens = @new_tokens + top_up
      return top_up
    end
    return 0
  end

  def print_user
    output_str = "  " + @last_name + ", " + @first_name +", " + @email + "\n" + "    Previous Token Balance, " \
    + @prev_tokens.to_s + "\n" + "    New Token Balance " + @new_tokens.to_s

    output_str
  end

end

class Challenge

  def initialize(companies_filename=nil, users_filename=nil)
    @companies_filename = companies_filename.nil? ? Dir.pwd + "/companies.json" : companies_filename
    @users_filename = users_filename.nil? ? Dir.pwd + "/users.json" : users_filename
    @companies = Hash.new()
  end

  def read_json_file(filename)
    read_file = File.read(filename)
    data_hash = JSON.parse(read_file)
    data_hash
  end

  def run_and_print_to_file(output_filename=nil)

    read_json_file(@companies_filename).each do |company|
      @companies[company["id"]] = Company.new(company["id"], company["name"], company["top_up"], company["email_status"])
    end

    # process the users
    read_json_file(@users_filename).each do |user|
      user_obj = Users.new(user["id"], user["first_name"],
                       user["last_name"], user["email"], user["company_id"],
                       user["email_status"], user["active_status"], user["tokens"].to_i)

      # next unless user_obj.valid?
      company = @companies[user["company_id"]]

      company.user_email_list(user_obj) if company
    end

    ordered_ids = @companies.keys.sort

    output_filename = output_filename.nil? ? Dir.pwd + "/output_1.txt" : output_filename

    File.open(output_filename, 'w') do |f|
      ordered_ids.each do |id|
        company = @companies[id]
        f.write(company.print_company)
      end
      f.close
    end
  end
end

# to print the output_1.txt file
Challenge.new(nil, nil).run_and_print_to_file(nil)
