class GithubPostReceiver < Sinatra::Application
  # TODO: Get options from command line or config file.
  OPTIONS = Object.new
  def OPTIONS.commands
    ['ls']
  end
  def OPTIONS.branch
    'master'
  end

  def parse_json(string)
    # We do the `empty?` checking because `JSON.parse` raises an exception when
    # given an empty string.
    json = JSON.parse(string) unless string.empty?
    ActiveSupport::HashWithIndifferentAccess.new(json)
  rescue JSON::ParserError
    halt 400
  end

  post '/' do
    halt 400 unless params[:payload]
    push = parse_json(params[:payload])
    halt 422 unless push[:ref]
    branch = push[:ref].match(/([^\/]+)$/)[0]

    if branch == OPTIONS.branch
      output = OPTIONS.commands.inject('') { |memo, cmd| memo << "\n" + `#{cmd}` }
      success = if $?
                  $?.success? ? true : false
                else
                  true
                end

      logger.method(success ? :info : :error).call("\n" + output)
      success ? 200 : 500
    else
      204
    end
  end
end
