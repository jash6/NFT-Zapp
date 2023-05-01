import React, { useState, useEffect, useContext } from "react";

//INTERNAL IMPORT
import Style from "../styles/author.module.css";
import { Banner, NFTCardTwo } from "../collectionPage/collectionIndex";
import { Brand, Title } from "../components/componentsindex";
import FollowerTabCard from "../components/FollowerTab/FollowerTabCard/FollowerTabCard";
import images from "../img";
import {
  AuthorProfileCard,
  AuthorTaps,
  AuthorNFTCardBox,
} from "../authorPage/componentIndex";

//IMPORT SMART CONTRACT DATA
import { NFTMarketplaceContext } from "../Context/NFTMarketplaceContext";

const author = () => {
  const followerArray = [
    {
      background: images.creatorbackground1,
      user: images.user1,
      seller: "7d64gf748849j47fy488444",
    },
    {
      background: images.creatorbackground2,
      user: images.user2,
      seller: "7d64gf748849j47fy488444",
    },
    {
      background: images.creatorbackground3,
      user: images.user3,
      seller: "7d64gf748849j47fy488444",
    },
    {
      background: images.creatorbackground4,
      user: images.user4,
      seller: "7d64gf748849j47fy488444",
    },
    {
      background: images.creatorbackground5,
      user: images.user5,
      seller: "7d64gf748849j47fy488444",
    },
    {
      background: images.creatorbackground6,
      user: images.user6,
      seller: "7d64gf748849j47fy488444",
    },
  ];

  const [collectiables, setCollectiables] = useState(true);
  const [created, setCreated] = useState(false);
  const [senderdashboard, setSenderDashboard] = useState(false);
  const [receiverdashboard, setReceiverDashboard] = useState(false);
  const [like, setLike] = useState(false);
  const [follower, setFollower] = useState(false);
  const [following, setFollowing] = useState(false);

  //IMPORT SMART CONTRACT DATA
  const { fetchMyNFTsOrListedNFTs, currentAccount, getAllExchanges } =
    useContext(NFTMarketplaceContext);

  const [nfts, setNfts] = useState([]);
  const [myNFTs, setMyNFTs] = useState([]);
  const [senderexchanges, setSenderExchanges] = useState([]);
  const [receiverexchanges, setReceiverExchanges] = useState([]);

  useEffect(() => {
    fetchMyNFTsOrListedNFTs("fetchItemsListed").then((items) => {
      setNfts(items);
    });
    fetchMyNFTsOrListedNFTs("fetchMyNFTs").then((items) => {
      setMyNFTs(items);
    });
    getAllExchanges("Sender").then((items) => {
      console.log("Senderrr", items);
      setSenderExchanges(items);
    });
    getAllExchanges("Receiver").then((items) => {
      console.log("Receiverrr", items);
      setReceiverExchanges(items);
    });
  }, []);

  return (
    <div className={Style.author}>
      <Banner bannerImage={images.creatorbackground2} />
      <AuthorProfileCard currentAccount={currentAccount} />
      <AuthorTaps
        setCollectiables={setCollectiables}
        setCreated={setCreated}
        setLike={setLike}
        setFollower={setFollower}
        setFollowing={setFollowing}
        setSenderDashboard={setSenderDashboard}
        setReceiverDashboard={setReceiverDashboard}
        currentAccount={currentAccount}
      />
      <AuthorNFTCardBox
        collectiables={collectiables}
        created={created}
        senderdashboard={senderdashboard}
        receiverdashboard={receiverdashboard}
        like={like}
        follower={follower}
        following={following}
        nfts={nfts}
        myNFTS={myNFTs}
        senderexchanges={senderexchanges}
        receiverexchanges={receiverexchanges}
      />
      <Title
        heading="Popular Creators"
        paragraph="Click on music icon and enjoy NTF music or audio
"
      />
      <div className={Style.author_box}>
        {followerArray.map((el, i) => (
          <FollowerTabCard i={i} el={el} />
        ))}
      </div>

      <Brand />
    </div>
  );
};

export default author;
