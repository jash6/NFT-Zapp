import React, { useContext } from "react";
import Image from "next/image";
import { Button } from "../../components/componentsindex";
import { FaWallet, FaPercentage } from "react-icons/fa";
import { NFTMarketplaceContext } from "../../Context/NFTMarketplaceContext";
import Style from "./Dashboard.module.css";
function Dashboard({ NFTData, type }) {
  const { withdraw, refund } = useContext(NFTMarketplaceContext);
  return (
    <div className={Style.Dash}>
      <table className={Style.tab}>
        <thead>
          <tr>
            {/* <th className={Style.th}>Sender</th>
            <th className={Style.th}>Receiver</th> */}
            <th className={Style.th}>Sender Token</th>
            <th className={Style.th}>Receiver Token</th>
            <th className={Style.th}> Action </th>
          </tr>
        </thead>
        <tbody>
          {NFTData.map((el, i) => {
            return (
              <tr key={i}>
                {/* <td className={Style.td}>
                  <small>{el.sender}</small>
                </td>
                <td className={Style.td}>
                  <small>{el.receiver}</small>
                </td> */}
                <td className={Style.td}>
                  <div>
                    <Image
                      src={el.image}
                      alt="profile"
                      width={100}
                      height={100}
                    />
                    {el.tokenId}
                  </div>
                </td>
                <td className={Style.td}>
                  <div>
                    <Image
                      src={el.image2}
                      alt="profile"
                      width={100}
                      height={100}
                    />
                  </div>
                  <div>{el.requestedid}</div>
                </td>
                <td className={Style.td}>
                  {type == "Receiver" ? (
                    <div>
                      <Button
                        icon={<FaWallet />}
                        btnName="Accept Zap"
                        handleClick={() => withdraw(el.tokenId, el.requestedid)}
                        classStyle={Style.button}
                      />
                      <Button
                        icon={<FaWallet />}
                        btnName="Reject Zap"
                        handleClick={() => refund(el.tokenId, el.requestedid)}
                        classStyle={Style.button}
                      />
                    </div>
                  ) : (
                    <Button
                      icon={<FaWallet />}
                      btnName="Refund Zap"
                      handleClick={() => refund(el.tokenId, el.requestedid)}
                      classStyle={Style.button}
                    />
                  )}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

export default Dashboard;
