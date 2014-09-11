require 'sinatra'
require 'openssl'
require 'base64'

helpers do 
  def decrypt(encrypted_data)
    padding = "=" * (4 - (encrypted_data.length % 4))
    epassword = "#{encrypted_data}#{padding}"
    decoded = Base64.decode64(epassword)

    key = "\x4e\x99\x06\xe8\xfc\xb6\x6c\xc9\xfa\xf4\x93\x10\x62\x0f\xfe\xe8\xf4\x96\xe8\x06\xcc\x05\x79\x90\x20\x9b\x09\xa4\x33\xb6\x6c\x1b"
    aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
    aes.decrypt
    aes.key = key
    plaintext = aes.update(decoded)
    plaintext << aes.final
    pass = plaintext.unpack('v*').pack('C*') # UNICODE conversion

    return pass
  end
end

get '/' do
  @decrypted = nil
  erb :index
end

post '/' do
  @decrypted = nil
  if !params[:password].nil?
    @decrypted = decrypt(params[:password])
  end
  erb :index
end

__END__

@@ index
<html>
  <head><title>MICRO-FUUUUUUUU</title></head>
  <body>
    <p>
      Enter your GPP encrypted password below and click submit.
    </p>
    <form method="POST" action="/">
      <input type="text" name="password" placeholder="Encrypted String" required>
      <input type="submit" value="Decrypt"/>
    </form>
    <% if !@decrypted.nil? %>
      <p>
        <b>Decrypted Password: </b><%=@decrypted%>
      </p>
    <% end %>
  </body>
</html>