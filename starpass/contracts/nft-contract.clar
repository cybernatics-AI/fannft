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

;; Stores metadata for each NFT
(define-map nft-metadata
    { nft-id: uint }
    { metadata: (string-utf8 256) }
)

;; Royalty information for each NFT
(define-map nft-royalties
    { nft-id: uint }
    { creator: principal, percentage: uint }
)

;; Leasing information for each NFT
(define-map nft-leases
    { nft-id: uint }
    { lessee: principal, lease-end: uint }
)

;; Counter for the total number of NFTs minted
(define-data-var total-nfts uint u0)

;; Maximum tier value
(define-constant MAX-TIER u10)

;; Mint function includes metadata and royalty info
(define-public (mint-nft (recipient principal) (tier uint) (metadata (string-utf8 256)) (royalty-percentage uint))
    (let
        (
            (nft-id (+ (var-get total-nfts) u1))
        )
        ;; Validate metadata length
        (asserts! (<= (len metadata) u256) (err u407))  ;; Error if metadata exceeds 256 characters
        ;; Validate royalty percentage (0-100)
        (asserts! (<= royalty-percentage u100) (err u408)) ;; Error if royalty percentage is above 100
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
        (map-set nft-metadata
            { nft-id: nft-id }
            { metadata: metadata }
        )
        (map-set nft-royalties
            { nft-id: nft-id }
            { creator: recipient, percentage: royalty-percentage }
        )
        (var-set total-nfts nft-id)
        (ok nft-id)
    )
)

;; Transfer function with royalty payments
(define-public (transfer-nft (nft-id uint) (recipient principal))
    (let
        (
            (current-owner (unwrap! (map-get? nft-owners { nft-id: nft-id }) (err u404)))
            (royalty-info (unwrap! (map-get? nft-royalties { nft-id: nft-id }) (err u405)))
        )
        ;; Check if the NFT exists
        (asserts! (<= nft-id (var-get total-nfts)) (err u404))
        ;; Check if the recipient is not the zero address
        (asserts! (not (is-eq recipient 'SP000000000000000000002Q6VF78)) (err u401))
        (asserts! (is-eq tx-sender (get owner current-owner)) (err u403))
        ;; Calculate and transfer royalty if applicable
        (let
            (
                (sale-price (stx-get-balance tx-sender)) ;; Placeholder for actual sale price
                (royalty-amount (/ (* sale-price (get percentage royalty-info)) u100))
            )
            (asserts! (> sale-price u0) (err u406)) ;; Check that sale price is greater than zero
            (try! (stx-transfer? royalty-amount tx-sender (get creator royalty-info)))
        )
        (try! (nft-transfer? fan-nft nft-id tx-sender recipient))
        (map-set nft-owners
            { nft-id: nft-id }
            { owner: recipient }
        )
        (ok true)
    )
)

;; Lease NFT
(define-public (lease-nft (nft-id uint) (lessee principal) (lease-duration uint))
    (let
        (
            (current-owner (unwrap! (map-get? nft-owners { nft-id: nft-id }) (err u404)))
        )
        ;; Validate that the NFT exists
        (asserts! (<= nft-id (var-get total-nfts)) (err u404))
        ;; Validate that the lease duration is greater than 0
        (asserts! (> lease-duration u0) (err u409))
        ;; Validate that lessee is not the zero address
        (asserts! (not (is-eq lessee 'SP000000000000000000002Q6VF78)) (err u401))
        ;; Verify owner is the transaction sender
        (asserts! (is-eq tx-sender (get owner current-owner)) (err u403))
        ;; Set leasing information
        (map-set nft-leases
            { nft-id: nft-id }
            { lessee: lessee, lease-end: (+ block-height lease-duration) }
        )
        (ok true)
    )
)

;; Function to check ownership or lease of an NFT
(define-read-only (get-current-holder (nft-id uint))
    (let
        (
            (lease-info (map-get? nft-leases { nft-id: nft-id }))
            (owner-info (unwrap! (map-get? nft-owners { nft-id: nft-id }) (err u404)))
        )
        (match lease-info
            some-lease
            (if (<= block-height (get lease-end some-lease))
                (ok (get lessee some-lease))
                (ok (get owner owner-info))
            )
            (ok (get owner owner-info))
        )
    )
)

;; Function to check the tier of an NFT
(define-read-only (get-tier (nft-id uint))
    (map-get? nft-tiers { nft-id: nft-id })
)

;; Function to retrieve NFT metadata
(define-read-only (get-metadata (nft-id uint))
    (map-get? nft-metadata { nft-id: nft-id })
)
