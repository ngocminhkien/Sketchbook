import React from "react";
import {
  splitTypographyProps,
  usePageTypography,
  type PageTypographyProps,
} from "./pageTypography";
import { LandingPageFrame, type LandingPageProps } from "./LandingPageFrame";
import { MENG_TO_SKETCHBOOK_TYPOGRAPHY } from "./pageRecipes";

export function MengToSketchbookLandingPage(props: LandingPageProps & PageTypographyProps) {
  const [type, frame] = splitTypographyProps(props);
  const customization = usePageTypography(MENG_TO_SKETCHBOOK_TYPOGRAPHY, type);
  return (
    <LandingPageFrame
      {...frame}
      customization={customization}
      title="Meng To — Southeast Asia Sketchbook"
      sourceUrl="/landing-pages/meng-to-sketchbook.html"
    />
  );
}

export default MengToSketchbookLandingPage;
