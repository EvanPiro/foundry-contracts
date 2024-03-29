// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";
import {ConfirmedOwner} from "lib/chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
//import {console} from "hardhat/console.sol";

/**
 * @title Functions Consumer contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner, ERC20 {
  using Functions for Functions.Request;

  struct RedeemRequest {
    address receiver;
    uint256 timestamp;
    bool redeemed;
  }

  string public source = "var a=args[0],c=args[1],d={url:`https://legiswipe.com/.netlify/functions/redeam?address=${a}&from=${c}`},e=await Functions.makeHttpRequest(d),f=Math.round(e.data['quantity']);return Functions.encodeUint256(f);";
  uint64 subId;
  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;

  mapping (address => uint256) public lastRedeemed;

  mapping (bytes32 => RedeemRequest) public redeemRequests;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  // https://github.com/protofire/solhint/issues/242
  // solhint-disable-next-line no-empty-blocks
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) ERC20("legiswipe", "LEGIS") {}

  function decimals() public view virtual override returns (uint8) {
    return 0;
  }

  function setSubId(uint64 _subId) onlyOwner public {
    subId = _subId;
  }

  /**
   * @notice Send a simple request
   *
   * @param receiver Address of the token redeemer account
   * @param gasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function executeRequest(
    address receiver,
    uint32 gasLimit
  ) public onlyOwner returns (bytes32) {
    require(subId != 0, "Subscription ID must be set before redeeming");

    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);

    string[] memory args = new string[](2);
    string memory receiverString = Strings.toHexString(receiver);
    string memory lastRedeemedString = Strings.toString(lastRedeemed[receiver]);

    args[0] = receiverString;
    args[1] = lastRedeemedString;

    req.addArgs(args);
    bytes32 assignedReqID = sendRequest(req, subId, gasLimit);

    uint256 timestamp = block.timestamp;
    redeemRequests[assignedReqID] = RedeemRequest(receiver, timestamp, false);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    latestResponse = response;
    latestError = err;
    uint256 redeemTime = block.timestamp;

    address receiver = redeemRequests[requestId].receiver;
    redeemRequests[requestId] = RedeemRequest(receiver, redeemTime, true);

    lastRedeemed[receiver] = redeemTime;

    uint256 amount = uint256(bytes32(response));

    super._mint(receiver, amount);
    emit OCRResponse(requestId, response, err);
  }

  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  function addSimulatedRequestId(address oracleAddress, bytes32 requestId) public onlyOwner {
    addExternalRequest(oracleAddress, requestId);
  }
}
