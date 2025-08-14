<?php

namespace Bede\PaymentGateway\Model\Payment;

use Bede\PaymentGateway\Helper\Data;
use Bede\PaymentGateway\Model\Payment\Bede;
use Bede\PaymentGateway\Model\Payment\PaymentRepository;

class MethodList
{
    protected $bede;
    protected $helper;
    protected $paymentRepository;

    public function __construct(Data $helper, PaymentRepository $paymentRepository,)
    {
        $this->helper = $helper;
        $this->paymentRepository = $paymentRepository;

        $this->bede = new Bede();
        $this->bede->baseURL = $helper->getBaseUrl();
        $this->bede->merchantID = $helper->getMerchantId();
        $this->bede->secretKey = $helper->getSecretKey();
        $this->bede->successURL = $helper->getSuccessUrl();
        $this->bede->failureURL = $helper->getFailureUrl();
        $this->bede->subMerchantID = $helper->getSubmerchantUid();

        if ((string)$this->bede->merchantID == "") {
            $this->bede->merchantID = "Mer2000012";
        }
        if ((string)$this->bede->merchantID == "") {
            $this->bede->merchantID = "1234567";
        }
    }

    public function getAvailableMethods()
    {
        // Call your API to get available methods
        $response = $this->bede->paymentMethods();

        $this->paymentRepository->addLog($this->bede->logData);

        return $response;
    }
}
