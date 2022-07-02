enum EraMode { buddhistYear, christYear }

int calculateYearEra(EraMode? era, int christYear) {
  if (era == EraMode.buddhistYear) {
    return christYear + 543;
  }
  return christYear;
}
