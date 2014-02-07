require 'digest/hmac'
require 'base64'
require 'httparty'

class SmsSender
  @@host = 'api.smsglobal.com'
  @@port = '443'
  @@request_url = '/v1/sms/'
  def initialize(client_id, client_secret)
    @client_id = client_id
    @secret = client_secret
  end

  def send(title, msg, mobile)
    @nonce = (0...8).map { (65 + rand(26)).chr }.join
    @ts = Time.now.to_i
    mac = calculate_mac
    header = {'Authorization' => "MAC id=\"#{@client_id}\", ts=\"#{@ts}\", nonce=\"#{@nonce}\", mac=\"#{mac}\"",
              'Content-Type' => 'application/json',
              'Accept' => 'application/json'}

    body = {"origin"=>title, "destination"=>mobile, "message"=>msg }

    response = HTTParty.post("https://#{@@host}#{@@request_url}", headers: header, body: body.to_json)
    response.code
  end

  private
  def calculate_mac
    body = "#{@ts}\n#{@nonce}\nPOST\n#{@@request_url}\n#{@@host}\n#{@@port}\n\n"
    digest = Digest::HMAC.digest(body, @secret, Digest::SHA256)
    Base64.strict_encode64 digest
  end
end