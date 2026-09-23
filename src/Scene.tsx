import React from "react";
import { MengToSketchbookLandingPage } from "./shaders/landing-pages/MengToSketchbookLandingPage";
import "./shaders/threeui.css";

export function Scene() {
  return (
    <div className="shader-frame" style={{ width: "100vw", height: "100vh", position: "relative" }}>
      <MengToSketchbookLandingPage
        headingFont="instrument-serif"
        bodyFont="newsreader"
        headingWeight="400"
        bodyWeight="400"
        primaryColor="#2b2721"
        headingSize={30}
        bodySize={20}
        headingLetterSpacing={0.010}
      />
    </div>
  );
}

export default Scene;
