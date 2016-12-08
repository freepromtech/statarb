ForexTradingFrameWork FXTrade;

class ForexTradingFrameWork
  {
    public String TradeId;
    
    public ForexTradingFrameWork()
      {
        TradeId = "";
        returned_value = "";
      }
    
    public void data_request( String instrument )
      {
         send_get_fx( "https://api-fxtrade.oanda.com/v1/prices?instruments=" + instrument );
      }
      
    public void validate_connection()
      {
        send_get_fx( "https://api-fxtrade.oanda.com/v1/accounts" );
      }
      
    public double account_pl()
      {
        send_get_fx( "https://api-fxtrade.oanda.com/v1/accounts/" + OandaAccount );
        double Val = 0;
        
        try
          {
            Object obj          = JSONValue.parse( returned_value );
            
            Val = ( ( double ) ( ( ( JSONObject ) obj ).get( "realizedPl" ) ) );
            
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
          
        return Val;
      }
      
    public double account_upl()
      {
        send_get_fx( "https://api-fxtrade.oanda.com/v1/accounts/" + OandaAccount );
        double Val = 0;
        
        try
          {
            Object obj          = JSONValue.parse( returned_value );
            
            Val = Double.parseDouble( "" + ( ( ( JSONObject ) obj ).get( "unrealizedPl" ) ) );
            
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
          
        return Val;
      }
      
    public double account_balance()
      {
        send_get_fx( "https://api-fxtrade.oanda.com/v1/accounts/" + OandaAccount );
        double Val = 0;
        
        try
          {
            Object obj          = JSONValue.parse( returned_value );
            
            Val = ( ( double ) ( ( ( JSONObject ) obj ).get( "balance" ) ) );
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
          
        return Val;
      }
      
    public AssetDataFrame get_data()
      {
        AssetDataFrame _return_ = new AssetDataFrame();
        _return_.SetValues( "", "-1", "-1" );
        
        try
          {
            Object obj          = JSONValue.parse( returned_value );
            
            JSONObject tick      = ( JSONObject ) obj;
            JSONArray  prices        = ( JSONArray )tick.get( "prices" );
            JSONObject  array = ( ( JSONObject )( prices ).get( 0 ) );
            
            String instrument = array.get( "instrument" ).toString();
            String time       = array.get( "time" ).toString();
            String bid        = array.get( "bid" ).toString();
            String ask        = array.get( "ask" ).toString();
            
            _return_.SetValues( instrument, bid, ask );
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
          
        return _return_;
      }
      
    public void send_order_ext( String instrument, String side, String units, String TakeProfit, String StopLoss )
      {
        send_post_fx( "https://api-fxtrade.oanda.com/v1/accounts/937471/orders/", "instrument=" + instrument + "&units=" + units + "&side=" + side + "&type=market&takeProfit=" + TakeProfit + "&stopLoss=" + StopLoss );
        
        Object obj       = JSONValue.parse( returned_value );
        
        JSONObject TradeData = ( JSONObject ) obj;
        JSONObject TradeConfig = ( JSONObject ) TradeData.get( "tradeOpened" );
      }
      
    public void send_order_ext2( String instrument, String side, String units, String TakeProfit )
      {
        send_post_fx( "https://api-fxtrade.oanda.com/v1/accounts/937471/orders/", "instrument=" + instrument + "&units=" + units + "&side=" + side + "&type=market&takeProfit=" + TakeProfit );
        
        Object obj       = JSONValue.parse( returned_value );
        
        JSONObject TradeData = ( JSONObject ) obj;
        JSONObject TradeConfig = ( JSONObject ) TradeData.get( "tradeOpened" );
      }
      
    public void send_order( String instrument, String side, String units )
      {
        try
          {
            send_post_fx( "https://api-fxtrade.oanda.com/v1/accounts/937471/orders/", "instrument=" + instrument + "&units=" + units + "&side=" + side + "&type=market" );
            
            Object obj       = JSONValue.parse( returned_value );
            
            JSONObject TradeData = ( JSONObject ) obj;
            JSONObject TradeConfig = ( JSONObject ) TradeData.get( "tradeOpened" );
            TradeId = ( String ) TradeConfig.get( "id" ).toString();
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
      }
      
    public void close_order( String instrument )
      {
        try
          {
          send_delete_fx( "https://api-fxtrade.oanda.com/v1/accounts/937471/positions/" + instrument );
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
      }
  }
