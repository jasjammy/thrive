require 'rspec/autorun'
require_relative './challenge.rb'
require 'fileutils'



describe "challenge" do
  it "takes valid companies.json and users.json and has valid output" do
    test_users_filename = Dir.pwd + "/test_users.json"
    test_companies_filename = Dir.pwd + "/test_companies.json"
    test_output_filename = Dir.pwd + "/test_valid_output.txt"
    c = Challenge.new(test_companies_filename, test_users_filename)
      .run_and_print_to_file(test_output_filename)

    valid_txt = Dir.pwd + "/test_valid.txt"
    expect(FileUtils.compare_file(valid_txt, test_output_filename)).to be_truthy
  end

  it "has valid output when users do not have a company" do
    test_users_filename = Dir.pwd + "/test_bad_users.json"
    test_companies_filename = Dir.pwd + "/test_companies.json"
    test_output_filename = Dir.pwd + "/test_invalid_output.txt"
    c = Challenge.new(test_companies_filename, test_users_filename)
      .run_and_print_to_file(test_output_filename)

    valid_txt = Dir.pwd + "/test_invalid.txt"
    expect(FileUtils.compare_file(valid_txt, test_output_filename)).to be_truthy
  end

  # it "has valid output when users do not have the right email" do
  #   test_users_filename = Dir.pwd + "/test_bad_users_email.json"
  #   test_companies_filename = Dir.pwd + "/test_companies.json"
  #   test_output_filename = Dir.pwd + "/test_invalid_user_email.txt"
  #   c = Challenge.new(test_companies_filename, test_users_filename)
  #     .run_and_print_to_file(test_output_filename)

  #   valid_txt = Dir.pwd + "/test_invalid_output_user_email.txt"
  #   expect(FileUtils.compare_file(valid_txt, test_output_filename)).to be_truthy
  # end
end
