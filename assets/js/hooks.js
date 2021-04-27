import flatpickr from "flatpickr";
import { AsYouType } from "libphonenumber-js";

let Hooks = {}

Hooks.InfiniteScroll = {
  mounted() {
    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        this.pushEvent("load-more");
      }
    });
    observer.observe(this.el);
  },
  updated() {
    const pageNumber = this.el.dataset.pageNumber;
    console.log("updated", pageNumber);
  }
}

Hooks.DatePicker = {
  mounted() {
    flatpickr(this.el, {
      enableTime: false,
      dateFormat: "F d, Y",
      onChange: this.handleDatePicked.bind(this),
    });
  },
  handleDatePicked(selectedDates, dateStr, instance) {
    this.pushEvent("select-date", dateStr);
  },
}

Hooks.PhoneNumberFormatter = {
  mounted() {
    this.el.addEventListener("input", e => {
      this.el.value = new AsYouType("US").input(this.el.value);
    });
  }
};

export default Hooks;
