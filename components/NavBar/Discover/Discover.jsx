import React from "react";
import Link from "next/link";

//INTERNAL IMPORT
import Style from "./Discover.module.css";

const Discover = () => {
  //--------DISCOVER NAVIGATION MENU
  const discover = [
    {
      name: "Collection",
      link: "collection",
    },
    {
      name: "Search",
      link: "searchPage",
    },
    {
      name: "Author Profile",
      link: "author",
    },
    {
      name: "NFT Details",
      link: "NFT-details",
    },
    {
      name: "Account Setting",
      link: "account",
    },
    {
      name: "Upload NFT",
      link: "uploadNFT",
    },
    {
      name: "Connect Wallet",
      link: "connectWallet",
    },
    {
      name: "Blog",
      link: "blog",
    },
  ];
  return (
    <div>
      {discover.map((el, i) => (
        <div key={i + 1} className={Style.discover}>
          <Link href={{ pathname: `${el.link}` }}>{el.name}</Link>
        </div>
      ))}
      <div className={Style.discover}>
        {/* <Link href="https://vestor-jaar.vercel.app/">Vesting</Link> */}
        <a
          href="https://vestor-jaar.vercel.app/"
          target="_blank"
          rel="noreferrer"
        >
          Vesting
        </a>
      </div>
      <div className={Style.discover}>
        {/* <Link href="https://nft-burner.vercel.app/">NFT Burning</Link> */}
        <a
          href="https://nft-burner.vercel.app/"
          target="_blank"
          rel="noreferrer"
        >
          NFT Burning
        </a>
      </div>
    </div>
  );
};

export default Discover;
