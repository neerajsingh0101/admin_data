require 'fileutils'

class AdminData::ValidateModelController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view

  def index
    @page_title = 'validate model'
    respond_to {|format| format.html}
  end

  def validate

    respond_to do |format|
      format.js do
        if !params[:still_processing].blank? 
            tid = params[:tid]
            data = gather_data(tid)
           processing_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'processing.txt')
           answer = File.exists?(processing_file) ? 'yes' : 'no' 
          render :json => {:still_processing => answer, :data => data }
        elsif params[:model].blank? || params[:model].empty?
          render :json => {:error => 'Please select at least one model' }
          return
        elsif params[:tid].blank?
          render :json => {:error => 'Something went wrong. Please try again !!' }
          return
        else
          start_validation
          data = gather_data(params[:tid])
          render :json => {:still_processing => 'yes' }
        end
      end
    end
  end

  private

  def start_validation
    tid = params[:tid]
    f = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid)
    FileUtils.rm_rf(f) if File.directory?(f)
    FileUtils.mkdir_p(f)

    bad_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'processing.txt')
    File.open(bad_file, 'a') {|f| f.puts('') }

    bad_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'bad.txt')
    File.open(bad_file, 'a') {|f| f.puts('') }

    good_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'good.txt')
    File.open(good_file, 'a') {|f| f.puts('') }

    klasses = params[:model].keys.join(',')
    call_rake('admin_data:validate_models_bg', {:tid => tid, :klasses => klasses} )
  end

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    command =  "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/tmp/admin_data/rake.log &"
    puts command
    system(command)
  end

  def gather_data(tid)
    sleep 3
    good_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'good.txt')
    bad_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'bad.txt')

    data = []
    File.open(bad_file, "r") do |f|
      f.each_line do |line|
        next if line.strip.blank?
        data << "<p>"
        r = /(\w+)\s+\|\s+(\d+)\s+\|\s+(.*)/
        m = r.match(line)
        Rails.logger.info("line is:"+line)
        Rails.logger.info(m.inspect)
        output = render_to_string(:partial => 'bad',
        :layout => false, :locals => {
          :klasss => m[1],
          :id => m[2],
        :error => m[3]})
        data << output
        data << '</p>'
      end
    end

    File.open(good_file, "r") do |f|
      f.each_line { |line| data << "<p>#{line}</p>" }
    end

    data.join
  end

end
