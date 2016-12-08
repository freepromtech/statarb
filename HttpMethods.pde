String returned_value = ""; 

public void send_get_fx( String url )
  {
    try
      {
        HttpClient client = new DefaultHttpClient();
        HttpGet request = new HttpGet( url );
        request.addHeader( "Authorization", "Bearer "+Token );

        HttpResponse response = client.execute( request );

        //System.out.println( "" +  "\nSending 'GET' request to URL : " + url );
        
        BufferedReader rd = new BufferedReader( new InputStreamReader( response.getEntity().getContent() ) );

        StringBuffer result = new StringBuffer();
        String line = "";
  
        while( ( line = rd.readLine() ) != null )
          {
            result.append( line );
          }
        
        returned_value = ( result.toString() );
      }
    catch ( Exception e )
      {
      }
  }
  
public void send_delete_fx( String url )
  {
    try
      {
        HttpClient client = new DefaultHttpClient();
        HttpDelete request = new HttpDelete( url );
        request.addHeader( "Authorization", "Bearer "+Token );
        
        HttpResponse response = client.execute( request );
        
        BufferedReader rd = new BufferedReader( new InputStreamReader( response.getEntity().getContent() ) );

        StringBuffer result = new StringBuffer();
        String line = "";
  
        while( ( line = rd.readLine() ) != null )
          {
            result.append( line );
          }
        
        returned_value = ( result.toString() );
      }
    catch ( Exception e )
      {
      }
  }
  
public void send_post_fx( String url, String body )
  {
    try
      {
        HttpClient client = new DefaultHttpClient();
        HttpPost post = new HttpPost( url );
        post.addHeader( "Authorization", "Bearer "+Token );
        HttpEntity entity = new ByteArrayEntity( body.getBytes("UTF-8"));
            post.setEntity( entity );
        post.addHeader( "Content-Type", "application/x-www-form-urlencoded" );
        
        HttpResponse response = client.execute(post);
        //System.out.println( "" + "\nSending 'POST' request to URL : " + url);
        //System.out.println( "" + "Post parameters : " + post.getEntity());
        //System.out.println( "" + "Response Code : " + 
                //                      response.getStatusLine().getStatusCode());

        BufferedReader rd = new BufferedReader(
                            new InputStreamReader(response.getEntity().getContent()));

        StringBuffer result = new StringBuffer();
        String line = "";
        
        while (  ( line = rd.readLine() ) != null )
          {
            result.append(line);
          }

        returned_value = ( result.toString() );
      }
    catch( Exception e )
      {
      }
  }  
