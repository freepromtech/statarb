import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.*;
import java.util.*;
import java.text.*;
import javax.swing.*;
import controlP5.*;

import org.apache.http.client.methods.HttpDelete;
import org.apache.http.*;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.*;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.client.methods.HttpDelete;

import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;
import org.json.simple.JSONArray;

AlertSystem Iterate1;
AlertSystem Iterate2;
int         Index;
double      pl;
double      upl;
double      bal;

void setup()
  {
    size( 900, displayHeight );
  
    if ( frame != null )
      {
        frame.setTitle( "Terminal" );
        frame.setResizable( true );
      }
    ES = new EconomicsStrategy();
    
    Iterate1 = new AlertSystem();
    Iterate2 = new AlertSystem();
  
    GRAPH_INTER = new GraphicsInterface( this );
    FXTrade     = new ForexTradingFrameWork();
  
    TE = new TradingEnviornment[ 5 ];
  
    TE[ 0 ] = new TradingEnviornment( "USD_SEK", "USD_DKK", 3000 );
    TE[ 1 ] = new TradingEnviornment( "AUD_USD", "NZD_USD", 3000 );
    
    delay( 1000 );
    
    TE[ 0 ].Trade( false, false );
    TE[ 1 ].Trade( false, true );
  
    Index = 0;
    
    pl = FXTrade.account_pl();
    upl = FXTrade.account_upl();
    bal = FXTrade.account_balance();
  }

void draw()
  {
    background( 64 );
    GRAPH_INTER.Draw();
    Iterate1.Update();
    Iterate2.Update();
    
    stroke( 0 );
    fill( 128 );
    rect( 25, height/4 * 3 + 25, width/2 - 50, height/4 - 50 );
    fill( 96 );
    rect( 50, height/4 * 3 + 50, width/2 - 100, height/4 - 100 );
    
    for( int i = 0; i < 5; i++ )
      {
        stroke( 0 );
        fill( 0 );
        line( 0, height/2 + ( i*( height/20 ) ), width, height/2 + ( i*( height/20 ) ) );  
      }
    
    line( ( width/2 ), height/2, ( width/2 ), height/8 *5.6 );  
    
    int ts = 24;
    
    textSize( ts );
    
    NumberFormat formatter = new DecimalFormat("0.0000");   
    
    text( "Unrealized PL: " + upl, 55, height/4 * 3 + 75 );
    text( "Realized PL: " + pl, 55, height/4 * 3 + 100 );
    text( "Balance: " + bal, 55, height/4 * 3 + 125 );
    text( "Realized ROE: " + formatter.format( pl/bal * 100 ) + "%", 55, height/4 * 3 + 150 );
    text( "Unrealized ROE: " + formatter.format( upl/bal * 100 ) + "%", 55, height/4 * 3 + 175 );
    text( "Total ROE: " + formatter.format( ( upl+pl )/bal * 100 ) + "%", 55, height/4 * 3 + 200 );
    
    for( int i = 0; i < 2; i++ )
      {
        text( "Pairs: " + TE[ i ].Pair1 + " " + TE[ i ].Pair2, 50, height/2 + ( i*( height/20 ) ) - ( ts/2 ) + ( height/20 ) );
      }
      
    for( int i = 0; i < 2; i++ )
      {
        text( "" + formatter.format( TE[ i ].Ratio ) + "   " + formatter.format( TE[ i ].Ratio*TE[ i ].Lower ) + "   " + formatter.format( TE[ i ].Ratio*TE[ i ].Upper ), ( width/1.9 ), height/2 + ( i*( height/20 ) ) - ( ts/2 ) + ( height/20 ) );
      }
    
    ES.AnalyzeData();
    
    if ( Iterate1.CheckLevel( 7 ) )
      { 
        if( Index == 0 )
          {
            pl = FXTrade.account_pl();
          }
          
        if( Index == 1 )
          {
            upl = FXTrade.account_upl();
          }
          
        if( Index == 2 )
          {
            bal = FXTrade.account_balance();
          }
      }
    else if ( Iterate2.CheckLevel( 60 ) )
      {
        if( minute() > 1 && minute() < 59 )
          {
            try
              {
                TE[ Index ].ApplyMachineLearning();
              }
            catch( Exception e )
              {
                e.printStackTrace();
              }
              
            delay( 1000 );
            
            try
              {
                if( Index > 0 )
                  {
                    TE[ Index ].Trade( false, true );
                  }
                else
                  {
                    TE[ Index ].Trade( false, false );
                  }
              }
            catch( Exception e )
              {
                e.printStackTrace(); 
              }
          }
          
        Index++;
        Index %= 3;
      }
  }
