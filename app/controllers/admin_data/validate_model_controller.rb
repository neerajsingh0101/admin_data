require 'fileutils'

class AdminData::ValidateModelController < AdminData::BaseController

  unloadable

  before_filter :ensure_is_allowed_to_view

  def validate
    @page_title = 'validate model'
    @tid = Time.now.strftime('%Y%m%d%H%M%S')
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
          done_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid , 'done.txt')
          answer = File.exists?(done_file) ? 'no' : 'yes'
          render :json => { :still_processing => answer,
            :data => data,
          :currently_processing_klass =>  currently_processing_klass(tid) }
        else
          tid = params[:tid]
          klasses = params[:model].keys.join(',')
          start_validation_rake_task(tid, klasses)
          base_url = request.protocol + request.host_with_port
          render :json => {:still_processing => 'yes', :base_url => base_url }
        end
      end
    end
  end

  private

  def start_validation_rake_task(tid, klasses)
    #FIXME
    f = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid)
    FileUtils.rm_rf(f) if File.directory?(f)
    FileUtils.mkdir_p(f)

    AdminData::Util.write_to_validation_file(tid, 'processing.txt', 'a', '')
    AdminData::Util.write_to_validation_file(tid, 'bad.txt', 'a', '')
    AdminData::Util.write_to_validation_file(tid, 'good.txt', 'a', '')

    call_rake('admin_data:validate_models_bg', {:tid => tid, :klasses => klasses} )
  end

  def call_rake(task, options = {})
    #FIXME
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    command =  "rake #{task} #{args.join(' ')}"
    Rails.logger.debug "command: #{command}"
    p1 = Process.fork { system(command) }
    Process.detach(p1)
  end

  def currently_processing_klass(tid)
    #FIXME
    processing_file = File.join(RAILS_ROOT, 'tmp', 'admin_data', 'validate_model', tid, 'processing.txt')
    File.readlines(processing_file).last
  end

  def gather_data(tid)
    #FIXME
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
