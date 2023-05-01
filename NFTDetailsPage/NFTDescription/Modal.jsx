import React, { useState, useEffect, useContext } from "react";
import Image from "next/image";
import Style from "./NFTDescription.module.css";
import { BsImages } from "react-icons/bs";
import { NFTMarketplaceContext } from "../../Context/NFTMarketplaceContext";
import { Button } from "../../components/componentsindex";
import { FaWallet, FaPercentage } from "react-icons/fa";

function Modal({ nft1 }) {
  const {
    currentAccount,
    newContract,

    fetchMyNFTsOrListedNFTs,
  } = useContext(NFTMarketplaceContext);
  const [nfts, setNfts] = useState([]);

  useEffect(() => {
    fetchMyNFTsOrListedNFTs("fetchItems").then((items) => {
      if (items) {
        setNfts(items.reverse());
      }
    });
  }, []);
  return (
    <div style={{ display: "flex" }}>
      {nfts.map((el, i) => (
        <div style={{ margin: 10 }} key={i + 1}>
          <div>
            <Image src={el.image} alt="NFT images" width={200} height={200} />
          </div>
          <div>
            <h4>
              {el.name} #{el.tokenId}
            </h4>
            <div>
              <Button
                icon={<FaWallet />}
                btnName="Select"
                handleClick={() => newContract(nft1, nfts[i])}
              />
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export default Modal;
