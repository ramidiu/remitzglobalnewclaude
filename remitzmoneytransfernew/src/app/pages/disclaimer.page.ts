import { Component } from '@angular/core';

@Component({
  selector: 'app-disclaimer',
  template: `
  <ion-content><div class="info-page">
    <div class="info-hero">
      <a class="info-back" href="/">&larr; Back to Home</a>
      <h1>Disclaimer</h1>
      <p>Please read this disclaimer carefully</p>
    </div>
    <div class="info-body">
      <p>The Remitz Ltd website contains information obtained from sources believed to be reliable and has been prepared in good faith and with all reasonable care. Remitz makes no warranty, express or implied, concerning the suitability, completeness, quality or exactness of the information and models provided in this website.</p>

      <p>No liability is borne by Remitz, its related associates, nor providers of information to users, or third parties for the accuracy of information or models contained in this website, or any omissions or errors therein. Remitz or its providers of information will not have any liability for the use, interpretation or implementation of the information or models contained herein by any user.</p>

      <p class="info-muted">Remitz Limited is a company registered in England &amp; Wales. Company Registration No: 07956213. Registered office: 193 Seven Sisters Road, Finsbury Park, London N4 3NG, United Kingdom. Tel: 020 7272 8722. E-mail: info@remitz.co.uk. Website: www.remitz.co.uk.</p>
      <p><a href="/contact-us">Contact us &rarr;</a></p>
    </div>
  </div></ion-content>`
})
export class DisclaimerPage {}
