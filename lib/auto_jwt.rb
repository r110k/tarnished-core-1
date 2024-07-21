class AutoJwt
  def initialize(app)
    @app = app
  end

  def call(env)
    #  状态码，响应头，响应体, 如果你写了下面一行代码， controller 里面的逻辑将不会再执行，会直接返回
    # [200, {}, ['Hello, World!', 'Tarnished!']]
    header = env['HTTP_AUTHORIZATION']
    # Bearer jwt
    jwt = header.split(' ')[1] rescue ''
    # payload ex: [{"user_id"=>24}, {"alg"=>"HS256"}]
    payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } rescue nil
    env['current_user_id'] = payload[0]['user_id'] rescue nil
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end