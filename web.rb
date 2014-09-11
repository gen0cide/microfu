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

  def unattend(encrypted_data)
    Base64.decode64(encrypted_data).unpack('v*').pack('C*')
  end
end

get '/' do
  @decrypted = nil
  @error = nil
  erb :index
end

post '/' do
  @decrypted = nil
  @error = nil
  if !params[:password].nil? && !params[:type].nil?
    begin
      case params[:type]
      when 'gpp'
        @decrypted = decrypt(params[:password])
      when 'unattend'
        @decrypted = unattend(params[:password])
      else
        @error = "Invalid selection."
        @decrypt = nil
      end
    rescue
      @decrypted = nil
      @error = "Invalid string."
    end
  end
  erb :index
end

__END__

@@ index
<html>
  <head>
    <title>MICROHARD -NOTSOFT</title>


    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

    <!-- Optional theme -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">

    <!-- Latest compiled and minified JavaScript -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
  </head>
  <body>
    <div class="container">
      <div class="page-header">
        <h1>BALLIN SO HARD</h1>
      </div>
      <p class="lead">
        Enter your microsoft loot below and click submit.
      </p>
      <form class="form-horizontal" method="POST" action="/">
        <input class="form-control" type="text" name="password" placeholder="Encrypted String" required>
        <select style="margin-top:10px;" class="form-control" name="type">
          <option value="gpp">Encrypted GPP</option>
          <option value="unattend">unattend.xml</option>          
        </select>
        <input style="margin-top:10px;" class="btn btn-primary" type="submit" value="Decrypt"/>
      </form>
      <hr/>
      <% if @decrypted %>
        <p>
          <b>Decrypted Password: </b><%=@decrypted%>
        </p>
        <p>
          <img src="http://ionetheurbandaily.files.wordpress.com/2012/05/50-cent-smiling.jpg?w=420">
        </p>
      <% end %>
      <% if @error %>
        <p>
          <b>Error: <%=@error%></b>
        </p>
      <% end %>
    </div>
  </body>
</html>