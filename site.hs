{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Text.Pandoc.Options
import Text.Pandoc.Extensions
import Text.Pandoc.Shared (eastAsianLineBreakFilter)
import Data.Monoid ((<>))

static = do
  match "css/*" $ route idRoute >> compile compressCssCompiler
  match "images/*" idCopy
  where idCopy = route idRoute >> compile copyFileCompiler

main :: IO ()
main = hakyll $ do
  static
  let ldr ctx i = loadAndApplyTemplate "templates/default.html" ctx i >>= relativizeUrls
  match "index.org" $ do
    route   $ setExtension "html"
    compile $ pandocChineseCompiler >>= ldr defaultContext
  match "pgp.org" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler >>= ldr defaultContext
  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocChineseCompiler
      >>= loadAndApplyTemplate "templates/post.html" postCtx
      >>= saveSnapshot "content"
      >>= ldr postCtx
  create ["posts.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx = listField "posts" postCtx (return posts)
                    <> constField "title" "Notes"
                    <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/posts.html" archiveCtx
        >>= ldr archiveCtx
  create ["feed.rss"] $ do
    route idRoute
    compile $ do
      let feedCtx = postCtx <> bodyField "description"
      posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
      renderAtom myFeedConfiguration feedCtx posts
  match "templates/*" $ compile templateBodyCompiler

postCtx :: Context String
postCtx = dateField "date" "%F" <> defaultContext

readerOpts :: ReaderOptions
readerOpts = def
  { readerExtensions = pandocExtensions
  }

writerOpts :: WriterOptions
writerOpts = def
  { writerHTMLMathMethod = KaTeX ""
  , writerExtensions     = pandocExtensions
  }

pandocChineseCompiler = pandocCompilerWithTransform readerOpts writerOpts eastAsianLineBreakFilter

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
  { feedTitle       = "hawnzug's blog"
  , feedDescription = "hawnzug's blog"
  , feedAuthorName  = "hawnzug"
  , feedAuthorEmail = "hawnzug@gmail.com"
  , feedRoot        = "https://hawnzug.me"
  }
