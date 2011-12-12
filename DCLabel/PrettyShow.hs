{-# LANGUAGE CPP #-}
#if defined(__GLASGOW_HASKELL__) && (__GLASGOW_HASKELL__ >= 702)
{-# LANGUAGE Trustworthy #-}
#endif
{-| This module exports a function 'prettyShow' that pretty prints 'Principal's,
'Disj'unctions, 'Conj'unctions, 'Label's and 'DCLabel's.
-}
module DCLabel.PrettyShow (PrettyShow(..), prettyShow) where

import DCLabel.Core
import DCLabel.Secrecy
import DCLabel.Integrity
#if defined(__GLASGOW_HASKELL__) && (__GLASGOW_HASKELL__ >= 702)
-- import safe Text.PrettyPrint
import Text.PrettyPrint
#else
import Text.PrettyPrint
#endif



-- | Class used to create a 'Doc' type of DCLabel-related types
class PrettyShow a where
	pShow :: a -> Doc -- ^ Convert to 'Doc'.

-- | Render a 'PrettyShow' type to a string.
prettyShow :: PrettyShow a => a -> String
prettyShow = render . pShow

instance PrettyShow Disj where
	pShow (MkDisj xs) = bracks $ showDisj xs
                where showDisj []     = empty
                      showDisj [x]    = pShow x 
                      showDisj (x:ys) = pShow x <+> ( text "\\/") <+> showDisj ys
		      bracks x = lbrack <> x <> rbrack

instance PrettyShow Conj where 
	pShow (MkConj [])     = empty
	pShow (MkConj (x:[])) = pShow x
	pShow (MkConj (x:xs)) = pShow x <+> (text "/\\") <+> pShow (MkConj xs)  
        
instance PrettyShow Label where 
	pShow MkLabelAll     = braces $ text "ALL"
	pShow l = let (MkLabel c) = toLNF l
                  in braces $ pShow c

instance PrettyShow DCLabel where 
	pShow (MkDCLabel s  i) = angle $ pShow s <+> comma <+> pShow i
		where angle txt = (text "<") <> txt <> (text ">")

instance PrettyShow Principal where
	pShow (MkPrincipal s) = text (show s)

instance PrettyShow TCBPriv where
	pShow (MkTCBPriv p) = pShow p
  
instance PrettyShow SLabel where
  	pShow (MkSLabel dcL) = pShow . secrecy $ dcL

instance PrettyShow ILabel where
  	pShow (MkILabel dcL) = pShow . integrity $ dcL
