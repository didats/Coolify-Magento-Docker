<?php

namespace Bede\PaymentGateway\Controller\Adminhtml\System\Config;

use Magento\Config\Controller\Adminhtml\System\Config\Save as SaveController;
use Magento\Store\Model\StoreManagerInterface;
use Magento\Backend\App\Action\Context;
use Magento\Config\Model\Config\Structure;
use Magento\Config\Controller\Adminhtml\System\ConfigSectionChecker;
use Magento\Config\Model\Config\Factory;
use Magento\Framework\Cache\FrontendInterface;
use Magento\Framework\Stdlib\StringUtils;

class Save extends SaveController
{
    protected $storeManager;
    protected $configStructure;
    protected $sectionChecker;
    protected $configFactory;
    protected $cache;
    protected $string;
    public function __construct(
        StoreManagerInterface $storeManager,
        Context $context,
        Structure $configStructure,
        ConfigSectionChecker $sectionChecker,
        Factory $configFactory,
        FrontendInterface $cache,
        StringUtils $string
    ) {
        $this->storeManager = $storeManager;
        parent::__construct(
            $context,
            $configStructure,
            $sectionChecker,
            $configFactory,
            $cache,
            $string
        );
    }
    public function execute()
    {
        $params = $this->_request->getParams();
        $scope = $this->getRequest()->getParam('scope');
        $scopeCode = $this->getRequest()->getParam('scope_code');

        if ($params['section'] == "bede_payment_connection") {
            $enable = $params['groups']['general']['fields']['enabled']['value'];

            if ($scope === 'websites' && $scopeCode) {
                $website = $this->storeManager->getWebsite($scopeCode);
                $currencyCode = $website->getDefaultCurrencyCode();
            } elseif ($scope === 'stores' && $scopeCode) {
                $store = $this->storeManager->getStore($scopeCode);
                $currencyCode = $store->getDefaultCurrencyCode();
            } else {
                // Default scope
                $currencyCode = $this->storeManager->getStore()->getDefaultCurrencyCode();
            }

            if ($enable == 1) {
                if ($currencyCode != 'KWD') {
                    $this->messageManager->addError('Currency must be KWD - ' . $currencyCode);
                    return $this->resultRedirectFactory->create()->setPath('adminhtml/system_config/edit', ['section' => 'bede_payment_connection']);
                }
            }
        }

        return parent::execute();
    }
}
