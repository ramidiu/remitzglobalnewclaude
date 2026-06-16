package com.remitz.modules.payout.nsano.dto;

import lombok.Data;

/** Request body for POST /api/payout/nsano/status. */
@Data
public class NsanoStatusRequest {

    /** Our transaction referenceNumber. */
    private String referenceNumber;
}
