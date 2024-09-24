;; Defines the NFT token and its properties
(define-non-fungible-token fan-nft uint)

;; Maps each NFT to its associated tier
(define-map nft-tiers 
    { nft-id: uint } 
    { tier: uint }
)

;; Stores the owner's address for each NFT
(define-map nft-owners 
    { nft-id: uint } 
    { owner: principal }
)

;; Counter for the total number of NFTs minted
(define-data-var total-nfts uint u0)

;; Maximum tier value
(define-constant MAX-TIER u10)

;; Function to mint a new NFT
(define-public (mint-nft (recipient principal) (tier uint))
    (let 
        (
            (nft-id (+ (var-get total-nfts) u1))
        )
        ;; Check if the tier is valid
        (asserts! (<= tier MAX-TIER) (err u400))
        ;; Check if the recipient is not the zero address
        (asserts! (not (is-eq recipient 'SP000000000000000000002Q6VF78)) (err u401))
        (try! (nft-mint? fan-nft nft-id recipient))
        (map-set nft-tiers 
            { nft-id: nft-id }
            { tier: tier }
        )
        (map-set nft-owners 
            { nft-id: nft-id }
            { owner: recipient }
        )
        (var-set total-nfts nft-id)
        (ok nft-id)
    )
)

;; Function to transfer an NFT
(define-public (transfer-nft (nft-id uint) (recipient principal))
    (let 
        (
            (current-owner (unwrap! (map-get? nft-owners { nft-id: nft-id }) (err u404)))
        )
        ;; Check if the NFT exists
        (asserts! (<= nft-id (var-get total-nfts)) (err u404))
        ;; Check if the recipient is not the zero address
        (asserts! (not (is-eq recipient 'SP000000000000000000002Q6VF78)) (err u401))
        (asserts! (is-eq tx-sender (get owner current-owner)) (err u403))
        (try! (nft-transfer? fan-nft nft-id tx-sender recipient))
        (map-set nft-owners
            { nft-id: nft-id }
            { owner: recipient }
        )
        (ok true)
    )
)

;; Function to check ownership of an NFT
(define-read-only (get-owner (nft-id uint))
    (map-get? nft-owners { nft-id: nft-id })
)

;; Function to check the tier of an NFT
(define-read-only (get-tier (nft-id uint))
    (map-get? nft-tiers { nft-id: nft-id })
)
