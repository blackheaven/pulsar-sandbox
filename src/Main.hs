{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (concurrently_)
import Control.Monad (forever)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as CL
import Data.Foldable (traverse_)
import Data.Text (Text)
import GHC.Generics (Generic)
import Pulsar
import Streamly (asyncly, maxThreads)
import qualified Streamly.Prelude as S

main :: IO ()
main = streamDemo

data Msg = Msg
  { name :: Text,
    amount :: Int
  }
  deriving (Generic, FromJSON, ToJSON, Show)

messages :: [PulsarMessage]
messages =
  let msg = [Msg "foo" 2, Msg "bar" 5, Msg "taz" 1]
   in PulsarMessage . encode <$> msg

msgDecoder :: CL.ByteString -> IO ()
msgDecoder bs =
  let msg = decode bs :: Maybe Msg
   in putStrLn $ "-----------------> " <> show msg

topic :: Topic
topic = defaultTopic "app"

sub :: Subscription
sub = Subscription Exclusive "test-sub"

conn :: PulsarConnection
conn = connect defaultConnectData

sleep :: Int -> IO ()
sleep n = threadDelay (n * 1000000)

logOpts :: LogOptions
logOpts = LogOptions Info StdOut

streamDemo :: IO ()
streamDemo = runPulsar' logOpts conn $ do
  c <- newConsumer topic sub
  p <- newProducer topic
  liftIO $ streamProgram c p

streamProgram :: Consumer IO -> Producer IO -> IO ()
streamProgram (Consumer fetch ack) (Producer send) =
  let c = forever $ fetch >>= \(Message i m) -> msgDecoder m >> ack i
      p = forever $ sleep 5 >> traverse_ send messages
   in S.drain . asyncly . maxThreads 10 $ S.yieldM c <> S.yieldM p
