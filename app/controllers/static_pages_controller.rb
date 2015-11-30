require 'twitter.rb'
require "#{Rails.root}/config/initializers/alchemyapi.rb"

class StaticPagesController < ApplicationController
  
  def home
  end

  def help
  end

  def about
  end

  def dashboard

  end

  def stocks
    y_client = YahooFinance::Client.new
    @stocks = Stock.all
    @data = y_client.quotes(@stocks.pluck(:symbol), [:name, :day_value_change, :bid, :sentiment])


    @stocks.each_with_index do |stock, index|
        @data[index].sentiment= sentiment(stock.symbol)
    end
  end

  def stocks_add
    Stock.create(symbol: params[:symbol])
    redirect_to stocks_url
  end

  def sentiment(stock_symbol)
    alchemyapi = AlchemyAPI.new()
        num_tweets=1
        total_score=0
        avg_sentiment= 0
        new_tweets_arr = Array.new

        tweets = $twitter.search('$' + stock_symbol + ' -rt',
                                   result_type: 'mixed',
                                   count: 20).take(5)

        # remove url from tweets
        tweets.each do |tweet|  
          tweet_no_url= tweet.text.dup
          tweet_no_url.gsub!(/(?:f|ht)tps?:\/[^\s]+/, '')
          new_tweets_arr.push(tweet_no_url)
        end

        # remove duplicates
        new_tweets_arr.uniq!
        new_tweets_arr.each do |tweet|  
          tweet_sentiment= alchemyapi.sentiment("text", tweet)
          if tweet_sentiment["status"] == 'OK' && tweet_sentiment["docSentiment"]["score"] != nil
            total_score += tweet_sentiment["docSentiment"]["score"].to_f
            num_tweets= num_tweets + 1
          end
        end

        avg_sentiment = total_score/num_tweets
        return avg_sentiment
  end

  def rankings

  end

  def history
    @user ||= User.find(session[:email]) if session[:email]
  end

  def contact

  end

end
