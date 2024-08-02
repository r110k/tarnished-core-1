class AutoJwt
  def initialize(app)
    @app = app
  end

  def call(env)
    #  状态码，响应头，响应体, 如果你写了下面一行代码， controller 里面的逻辑将不会再执行，会直接返回
    # [200, {}, ['Hello, World!', 'Tarnished!']]

    # jwt 跳过白名单
    return @app.call(env) if ['/', '/api/v1/session', '/api/v1/validation_codes'].include? env['PATH_INFO']

    header = env['HTTP_AUTHORIZATION']
    # Bearer jwt
    jwt = header.split(' ')[1] rescue ''
    begin
      # payload ex: [{"user_id"=>24}, {"alg"=>"HS256"}]
      payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' }
    rescue JWT::ExpiredSignature
      return [401, { 'Content-Type' => 'application/json; charset=UTF-8' }, [JSON.generate({ reason: 'token 失效' })]]
    rescue
      return [401, { 'Content-Type' => 'application/json; charset=UTF-8' }, [JSON.generate({ reason: 'token 非法' })]]
    end
    env['current_user_id'] = payload[0]['user_id'] rescue nil
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end
end