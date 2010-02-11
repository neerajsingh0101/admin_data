require 'fileutils'

class AdminData::ValidateModelController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view

  def tid
    @data = gather_data(params[:tid])
    respond_to {|format| format.html}
  end

  def validate
    @page_title = 'validate model'
    @tid = Time.now.strftime('%Y%m%d%H%M%S')

    dir = Rails.root.join('tmp', 'admin_data', 'validate_model')
    FileUtils.mkdir_p(dir)
    tids = Dir.chdir(dir) { Dir["*"] }
    @tids = tids.sort!

    respond_to {|format| format.html}
  end

  def validate_model
    respond_to do |format|
      format.js do
        if params[:tid].blank?
          render :json => {:error => 'Something went wrong. Please try again !!' }
          return

        elsif params[:model].blank? && params[:still_processing].blank?
          render :json => {:error => 'Please select at least one model' }
          return

        elsif !params[:still_processing].blank?
          tid = params[:tid]
          data = gather_data(tid)
          done_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'done.txt')
          answer = File.exists?(done_file) ? 'no' : 'yes'
          h = {
            :still_processing => answer,
            :data => data,
            :currently_processing_klass =>  AdminData::Util.read_validation_file(tid, 'processing.txt')
          }
          render :json => h
          return
        else
          tid = params[:tid]
          klasses = params[:model].keys.join(',')
          start_validation_rake_task(tid, klasses)
          base_url = request.protocol + request.host_with_port
          render :json => {:still_processing => 'yes', :base_url => base_url }
          return
        end
      end
    end
  end

  private

  def start_validation_rake_task(tid, klasses)
    f = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid)
    FileUtils.rm_rf(f) if File.directory?(f)
    FileUtils.mkdir_p(f)

    AdminData::Util.write_to_validation_file('', 'a', tid, 'processing.txt')
    AdminData::Util.write_to_validation_file('', 'a', tid, 'bad.txt')
    AdminData::Util.write_to_validation_file('', 'a', tid, 'good.txt')
    AdminData::Util.write_to_validation_file('', 'a', tid, 'error.txt')

    call_rake('admin_data:validate_models_bg', {:tid => tid, :klasses => klasses} )
  end

  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    rake_command = AdminDataConfig.setting[:rake_command]
    command =  "#{rake_command} #{task} #{args.join(' ')}"
    Rails.logger.info "command: #{command}"
    p1 = Process.fork { system(command) }
    AdminData::Util.write_to_validation_file(p1, 'a', options[:tid], 'pid.txt')
    Process.detach(p1)
  end

  def gather_data(tid)
    good_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'good.txt')
    bad_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'bad.txt')
    regex = /(\w+)\s+\|\s+(\d+)\s+\|\s+(.*)/

    data = []
    File.open(bad_file, "r") do |f|
      f.each_line do |line|
        next if line.strip.blank?
        data << '<p>'
        m = regex.match(line)
        data << render_to_string(:partial => 'bad', :locals => {:klassu => m[1], :id => m[2], :error => m[3]})
        data << '</p>'
      end
    end
    File.open(good_file, "r") { |f| f.each_line { |line| data << "<p>#{line}</p>" } }
    data.join
  end

end
