require 'sladon'

class Sladon::Client
  CONNECTION_OPENED = Object.new.freeze
  CONNECTION_CLOSED = Object.new.freeze

  def initialize(config)
    @base_url = config.base_url
    @bearer_token = config.bearer_token
    @rest_client = Mastodon::REST::Client.new(base_url: base_url, bearer_token: bearer_token)
    @streaming_url = URI.join(base_url, '/api/v1/streaming/').to_s
    @queue = Queue.new
    @logger = Logger.new(STDOUT)
    @notifier = Slack::Notifier.new(config.webhook_url)
    @ws = connect
  end
  attr_reader :base_url, :bearer_token, :rest_client, :streaming_url, :ws, :logger, :notifier

  def connect
    c = self
    q = @queue
    l = @logger
    WebSocket::Client::Simple.connect(streaming_url + "?access_token=#{bearer_token}&stream=user").tap do |ws|
      ws.on :open do
        l.info('sladon: connected')
        q.enq(CONNECTION_OPENED)
      end

      ws.on :close do |_e|
        l.info('sladon: disconnected')
        q.enq(CONNECTION_CLOSED)
      end

      ws.on :error do |e|
        l.error("#{e.class}: #{e.message}")
        q.enq(CONNECTION_CLOSED)
      end

      ws.on(:message) do |msg|
        case msg.type
        when :ping
          l.info('sladon: Received ping message')
          send('', type: 'pong')
        when :pong
          l.info('sladon: Received pong message')
        when :text
          c.on_message(msg)
        end
      end
    end
  rescue => e
    logger.error(e)
  end

  def on_message(msg)
    return if msg.data.size.zero?

    begin
      data = Oj.load(msg.data)
      return if data['event'] != 'notification'

      payload = Oj.load(data['payload'])
      return if payload['type'] != 'mention'

      logger.debug(payload)
      result = notifier.ping(build_slack(payload))
      logger.info(payload)
      logger.debug(result)
    rescue => e
      logger.error("#{e.class}: #{e.message}")
    end
  end

  def start
    keep_connection

    loop do
      message = @queue.deq
      break if message.equal?(CONNECTION_CLOSED)
    end
  end

  def keep_connection
    ws = @ws
    Thread.start do
      loop do
        sleep(30)
        ws.send('', type: 'ping')
      end
    end
  end

  def build_slack(payload)
    text = payload['status']['content'].to_s.gsub(/<[^>]*>/, '')
    {
      attachments: [
        {
          color: '#444b5d',
          text: text,
          author_name: "@#{payload['account']['username']}",
          author_link: payload['account']['url'],
          author_icon: URI.join(base_url, payload['account']['avatar_static'])
        }
      ]
    }
  end
end
