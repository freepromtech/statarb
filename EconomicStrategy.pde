EconomicsStrategy ES;

class EconomicsStrategy
  {
    TimeSeries Claims;
    TimeSeries ClaimsEst;
    
    AlertSystem Cycle;
    
    boolean Open;
    double ClaimsFig;
    
    public EconomicsStrategy()
      {
        Cycle = new AlertSystem();
        
        Claims = new TimeSeries();
        Claims.DownloadInitialClaims();
        
        ClaimsEst = new TimeSeries();
        ClaimsEst.DownloadInitialClaimsForecast();
        
        ClaimsFig = Claims.GetAsk( Claims.Series.size()-1 );
        System.out.println( ( new Date().toString() ) + "› Jobless Claims Surprise - " + ( ClaimsEst.GetAsk( ClaimsEst.Series.size()-1 ) - ClaimsFig ) );
                
        Open = false;
      }
      
    void AnalyzeData()
      {
        if( Open )
          {
            Cycle.Update();
          }
          
        if( Cycle.CheckLevel( 3600 ) )
          {
            Open = false;
            FXTrade.close_order( "USDJPY" );
          }
        
        try
          {
            ClaimsEst.DownloadInitialClaimsForecast();
            Claims.DownloadInitialClaims();
                
            if( Claims.GetAsk( Claims.Series.size()-1 ) != ClaimsFig )
              {
                System.out.println( ( new Date().toString() ) + "› Jobless Claims Surprise - " + ( ClaimsEst.GetAsk( ClaimsEst.Series.size()-1 ) - ClaimsFig ) );
                
                if( ClaimsEst.GetAsk( Claims.Series.size()-1 ) - ClaimsFig >= 0 )
                  {
                    Open = true;
                    FXTrade.send_order( "USD_JPY", "buy", "10000" );
                  }
                  
                if( ClaimsEst.GetAsk( Claims.Series.size()-1 ) - ClaimsFig <= 0 )
                  {
                    Open = true;
                    FXTrade.send_order( "USD_JPY", "sell", "10000" );
                  }
                  
                ClaimsFig = Claims.GetAsk( Claims.Series.size()-1 );
              }
          }
        catch( Exception e )
          {
            e.printStackTrace();
          }
          
        delay( 1000 );
      }
  }
